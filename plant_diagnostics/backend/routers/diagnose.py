from fastapi import APIRouter, File, UploadFile, HTTPException
from pydantic import BaseModel
import anthropic
import base64
import json
import logging
import os

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/diagnose", tags=["diagnosis"])

client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

SYSTEM_PROMPT = """You are CropGuard, an expert plant pathologist AI assistant.

Your task: analyze a leaf image and return a structured JSON diagnosis.

RULES:
1. First determine if the image contains a plant/leaf. If it does NOT (selfie, wall, object, etc.), 
   set is_plant=false and return immediately.
2. If it IS a plant, classify the disease or health status.
3. Confidence must be CALIBRATED — reflect genuine uncertainty. Do not inflate.
   - 0.9+ only for textbook-clear cases with multiple visible symptoms
   - 0.7–0.89 for likely but not certain
   - 0.5–0.69 for plausible but ambiguous image quality or symptoms
   - Below 0.5 = low confidence, say so clearly
4. Treatment advice must be GROUNDED — cite known agronomic practices only.
   Do not invent remedies. If unsure, say "consult a local agronomist."
5. Severity: "mild", "moderate", or "severe"

RESPOND ONLY WITH THIS JSON (no markdown, no explanation outside JSON):
{
  "is_plant": true,
  "disease_name": "Late blight (Phytophthora infestans)",
  "confidence": 0.82,
  "severity": "moderate",
  "summary": "Dark water-soaked lesions with pale green halos visible on the leaf edges, consistent with early-stage late blight infection.",
  "treatments": [
    "Remove and destroy infected plant material immediately",
    "Apply copper-based fungicide (e.g. Bordeaux mixture) as a preventive measure",
    "Ensure adequate plant spacing for airflow",
    "Avoid overhead irrigation to reduce leaf wetness"
  ],
  "disclaimer": "Diagnosis is AI-generated. Verify with a certified agronomist before large-scale treatment."
}

If NOT a plant, respond:
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
    """
    Accepts a leaf image and returns a structured disease diagnosis
    with calibrated confidence and grounded treatment advice.
    
    Rejects non-plant images (OOD rejection).
    """
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    contents = await image.read()
    if len(contents) > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(status_code=400, detail="Image too large (max 10MB)")

    image_b64 = base64.standard_b64encode(contents).decode("utf-8")
    media_type = image.content_type or "image/jpeg"

    try:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": image_b64,
                            },
                        },
                        {
                            "type": "text",
                            "text": "Analyze this image and provide the diagnosis JSON.",
                        },
                    ],
                }
            ],
        )

        raw_text = response.content[0].text.strip()
        
        # Strip markdown code fences if present
        if raw_text.startswith("```"):
            raw_text = "\n".join(raw_text.split("\n")[1:])
            if raw_text.endswith("```"):
                raw_text = raw_text[:-3]

        data = json.loads(raw_text)

        # Clamp confidence to [0, 1]
        if data.get("confidence") is not None:
            data["confidence"] = max(0.0, min(1.0, float(data["confidence"])))

        return DiagnosisResponse(**data)

    except json.JSONDecodeError as e:
        logger.error(f"JSON parse error from Claude: {e}\nRaw: {raw_text}")
        raise HTTPException(
            status_code=502,
            detail="Model returned invalid response format. Please retry.",
        )
    except anthropic.APIConnectionError:
        raise HTTPException(
            status_code=503,
            detail="AI service temporarily unavailable. Please retry shortly.",
        )
    except anthropic.RateLimitError:
        raise HTTPException(
            status_code=429,
            detail="Rate limit reached. Please wait a moment and retry.",
        )
    except Exception as e:
        logger.exception("Unexpected error in diagnose endpoint")
        raise HTTPException(status_code=500, detail=str(e))
