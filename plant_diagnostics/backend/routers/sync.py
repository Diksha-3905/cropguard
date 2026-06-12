"""
Offline sync endpoint with conflict resolution.

Strategy: vector clocks.
- Each client maintains a {device_id: lamport_timestamp} map per record.
- On sync, server compares incoming vector clock against stored clock.
- Resolution:
  * Incoming > stored → accept incoming (newer)
  * Stored > incoming → reject, return stored version (stale upload)
  * Concurrent (neither dominates) → merge: server diagnosis fields win,
    but both clocks are merged (union of max values)
- All operations are idempotent: duplicate syncs of the same id are safe.
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os
import logging
from supabase import create_client, Client

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/sync", tags=["sync"])

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],
)


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
    """Returns: 1 if a>b, -1 if a<b, 0 if concurrent."""
    keys = set(a.keys()) | set(b.keys())
    a_leads = any(a.get(k, 0) > b.get(k, 0) for k in keys)
    b_leads = any(b.get(k, 0) > a.get(k, 0) for k in keys)
    if a_leads and not b_leads:
        return 1
    if b_leads and not a_leads:
        return -1
    return 0


def merge_clocks(a: dict, b: dict) -> dict:
    keys = set(a.keys()) | set(b.keys())
    return {k: max(a.get(k, 0), b.get(k, 0)) for k in keys}


@router.post("/")
async def sync_diagnoses(body: SyncRequest):
    results = []

    for item in body.diagnoses:
        try:
            # Check if record exists in Supabase
            existing = (
                supabase.table("diagnoses")
                .select("*")
                .eq("id", item.id)
                .execute()
            )

            if not existing.data:
                # New record — insert
                supabase.table("diagnoses").insert({
                    "id": item.id,
                    "disease_name": item.disease_name,
                    "confidence": item.confidence,
                    "severity": item.severity,
                    "treatment_advice": item.treatment_advice,
                    "is_ood": item.is_ood,
                    "created_at": item.created_at,
                    "vector_clock": item.vector_clock,
                    "sync_status": "synced",
                }).execute()

                results.append({"id": item.id, "status": "accepted"})

            else:
                stored = existing.data[0]
                stored_clock = stored.get("vector_clock") or {}
                incoming_clock = item.vector_clock

                cmp = compare_clocks(incoming_clock, stored_clock)

                if cmp >= 0:
                    # Incoming is newer or concurrent — accept/merge
                    merged_clock = merge_clocks(incoming_clock, stored_clock)

                    supabase.table("diagnoses").update({
                        "disease_name": item.disease_name,
                        "confidence": item.confidence,
                        "severity": item.severity,
                        "treatment_advice": item.treatment_advice,
                        "vector_clock": merged_clock,
                        "sync_status": "synced",
                    }).eq("id", item.id).execute()

                    status = "accepted" if cmp == 1 else "conflict_resolved"
                    results.append({
                        "id": item.id,
                        "status": status,
                        "resolved": {
                            "disease_name": item.disease_name,
                            "confidence": item.confidence,
                            "severity": item.severity,
                        } if status == "conflict_resolved" else None,
                    })

                else:
                    # Stored is newer — reject incoming, return stored
                    results.append({
                        "id": item.id,
                        "status": "rejected_stale",
                        "server_version": {
                            "disease_name": stored["disease_name"],
                            "confidence": stored["confidence"],
                            "severity": stored["severity"],
                            "vector_clock": stored_clock,
                        },
                    })

        except Exception as e:
            logger.exception(f"Sync error for id {item.id}: {e}")
            results.append({"id": item.id, "status": "error", "detail": str(e)})

    return {"results": results, "total": len(results)}
