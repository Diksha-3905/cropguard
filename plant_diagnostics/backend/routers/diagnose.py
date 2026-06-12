from fastapi import APIRouter, File, UploadFile, HTTPException
from pydantic import BaseModel
import google.generativeai as genai
import base64
import json
import logging
import os

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/diagnose", tags=["diagnosis"])

genai.configure(api_key=os.environ["GEMINI_API_KEY"])
model = genai.GenerativeModel("gemini-1.5-flash")

PROMPT = """You are CropGuard, an expert plant pathologist AI assistant.

Analyze this leaf image and return ONLY a JSON response — no markdown, no explanation.

RULES:
1. First check if the image contains a plant/leaf. If NOT (selfie, wall, object), set is_plant=false.
2. Confidence must be CALIBRATED:
   - 0.9+ only for textbook-clear cases
   - 0.7-0.89 for likely but not certain
   - 0.5-0.69 for ambiguous
   - below 0.5 = low confidence
3. Treatments must be real agronomic practices only.
4. Severity: "mild", "moderate", or "severe"

Respond ONLY with this JSON:
{
  "is_plant": true,
  "disease_name": "Late blight (Phytophthora infestans)",
  "confidence": 0.82,
  "severity": "moderate",
  "summary": "Dark water-soaked lesions visible on leaf edges consistent with late blight.",
  "treatments": [
    "Remove and destroy infected plant material immediately",
    "Apply copper-based fungicide (Bordeaux mixture)",
    "Ensure adequate plant spacing for airflow",
    "Avoid overhead irrigation"
  ],
  "disclaimer": "AI-generated diagnosis. Verify with a certified agronomist before large-scale treatment."
}

If NOT a plant:
{
  "is_plant": false,
  "disease_name": null,
  "confidence": null,
  "severity": null,
  "summary": "The image does not appear to contain a plant or leaf.",
  "treatments": [],
  "disclaimer": null
}"""


class DiagnosisResponse(BaseModel):
    is_plant: bool
    disease_name: str | None
    confidence: float | None
    severity: str | None
    summary: str
    treatments: list[str]
    disclaimer: str | None


@router.post("/", response_model=DiagnosisResponse)
async def diagnose_image(image: UploadFile = File(...)):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    contents = await image.read()
    if len(contents) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image too large (max 10MB)")

    image_b64 = base64.standard_b64encode(contents).decode("utf-8")
    media_type = image.content_type or "image/jpeg"

    try:
        image_part = {
            "inline_data": {
                "mime_type": media_type,
                "data": image_b64,
            }
        }

        response = model.generate_content([PROMPT, image_part])
        raw_text = response.text.strip()

        # Strip markdown fences if present
        if raw_text.startswith("```"):
            lines = raw_text.split("\n")
            raw_text = "\n".join(lines[1:])
            if raw_text.endswith("```"):
                raw_text = raw_text[:-3].strip()

        data = json.loads(raw_text)

        if data.get("confidence") is not None:
            data["confidence"] = max(0.0, min(1.0, float(data["confidence"])))

        return DiagnosisResponse(**data)

    except json.JSONDecodeError as e:
        logger.error(f"JSON parse error: {e}\nRaw: {raw_text}")
        raise HTTPException(status_code=502, detail="Model returned invalid format. Please retry.")
    except Exception as e:
        logger.exception("Error in diagnose endpoint")
        raise HTTPException(status_code=500, detail=str(e))
