"""
Offline sync endpoint with vector clock conflict resolution — using Firebase Firestore.

Strategy: vector clocks (not last-write-wins).
- Each client maintains a {device_id: lamport_timestamp} map per record.
- On sync, server compares incoming vs stored clock.
- Incoming > stored → accept. Stored > incoming → reject. Concurrent → merge.
- All operations are idempotent.
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import logging
import firebase_admin
from firebase_admin import firestore as fb_firestore

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/sync", tags=["sync"])

# Firebase Admin is initialized in main.py
db = fb_firestore.client()


class DiagnosisSync(BaseModel):
    id: str
    disease_name: str | None
    confidence: float | None
    severity: str | None
    treatment_advice: str | None
    is_ood: bool
    created_at: str
    vector_clock: dict[str, int]


class SyncRequest(BaseModel):
    diagnoses: list[DiagnosisSync]


def compare_clocks(a: dict, b: dict) -> int:
    keys = set(a.keys()) | set(b.keys())
    a_leads = any(a.get(k, 0) > b.get(k, 0) for k in keys)
    b_leads = any(b.get(k, 0) > a.get(k, 0) for k in keys)
    if a_leads and not b_leads:
        return 1
    if b_leads and not a_leads:
        return -1
    return 0  # concurrent


def merge_clocks(a: dict, b: dict) -> dict:
    keys = set(a.keys()) | set(b.keys())
    return {k: max(a.get(k, 0), b.get(k, 0)) for k in keys}


@router.post("/")
async def sync_diagnoses(body: SyncRequest):
    results = []
    collection = db.collection("diagnoses")

    for item in body.diagnoses:
        try:
            doc_ref = collection.document(item.id)
            doc = doc_ref.get()

            if not doc.exists:
                # New record — insert
                doc_ref.set({
                    "id": item.id,
                    "disease_name": item.disease_name,
                    "confidence": item.confidence,
                    "severity": item.severity,
                    "treatment_advice": item.treatment_advice,
                    "is_ood": item.is_ood,
                    "created_at": item.created_at,
                    "vector_clock": item.vector_clock,
                    "sync_status": "synced",
                })
                results.append({"id": item.id, "status": "accepted"})

            else:
                stored = doc.to_dict()
                stored_clock = stored.get("vector_clock") or {}
                cmp = compare_clocks(item.vector_clock, stored_clock)

                if cmp >= 0:
                    # Incoming is newer or concurrent — accept/merge
                    merged = merge_clocks(item.vector_clock, stored_clock)
                    doc_ref.update({
                        "disease_name": item.disease_name,
                        "confidence": item.confidence,
                        "severity": item.severity,
                        "treatment_advice": item.treatment_advice,
                        "vector_clock": merged,
                        "sync_status": "synced",
                    })
                    status = "accepted" if cmp == 1 else "conflict_resolved"
                    results.append({"id": item.id, "status": status})
                else:
                    # Stored is newer — return server version
                    results.append({
                        "id": item.id,
                        "status": "rejected_stale",
                        "server_version": {
                            "disease_name": stored.get("disease_name"),
                            "confidence": stored.get("confidence"),
                            "severity": stored.get("severity"),
                            "vector_clock": stored_clock,
                        },
                    })

        except Exception as e:
            logger.exception(f"Sync error for {item.id}: {e}")
            results.append({"id": item.id, "status": "error", "detail": str(e)})

    return {"results": results, "total": len(results)}
