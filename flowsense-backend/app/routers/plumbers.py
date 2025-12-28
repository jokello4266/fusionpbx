from fastapi import APIRouter, Query
from typing import List
from app import schemas
import math

router = APIRouter()

# Mock plumber data - in production, this would come from a database or external API
MOCK_PLUMBERS = [
    {
        "name": "AquaFlow Plumbing",
        "rating": 4.8,
        "phone": "+1234567890",
        "address": "123 Main St, City, State 12345",
        "base_lat": 40.7128,
        "base_lon": -74.0060,
    },
    {
        "name": "WaterWorks Solutions",
        "rating": 4.6,
        "phone": "+1234567891",
        "address": "456 Oak Ave, City, State 12345",
        "base_lat": 40.7580,
        "base_lon": -73.9855,
    },
    {
        "name": "Precision Plumbing",
        "rating": 4.9,
        "phone": "+1234567892",
        "address": "789 Elm St, City, State 12345",
        "base_lat": 40.7505,
        "base_lon": -73.9934,
    },
    {
        "name": "FlowMaster Services",
        "rating": 4.7,
        "phone": "+1234567893",
        "address": "321 Pine Rd, City, State 12345",
        "base_lat": 40.7282,
        "base_lon": -74.0776,
    },
    {
        "name": "HydroTech Plumbing",
        "rating": 4.5,
        "phone": "+1234567894",
        "address": "654 Maple Dr, City, State 12345",
        "base_lat": 40.7614,
        "base_lon": -73.9776,
    },
]

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two coordinates in miles using Haversine formula."""
    R = 3959  # Earth radius in miles
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.asin(math.sqrt(a))
    return R * c

@router.get("/plumbers", response_model=List[schemas.PlumberResponse])
async def find_plumbers(
    latitude: float = Query(..., description="User latitude"),
    longitude: float = Query(..., description="User longitude"),
):
    """Find plumbers near the user's location."""
    plumbers_with_distance = []
    
    for plumber in MOCK_PLUMBERS:
        distance = calculate_distance(
            latitude,
            longitude,
            plumber["base_lat"],
            plumber["base_lon"],
        )
        plumbers_with_distance.append({
            "name": plumber["name"],
            "rating": plumber["rating"],
            "distance": round(distance, 1),
            "phone": plumber["phone"],
            "address": plumber["address"],
        })
    
    # Sort by distance
    plumbers_with_distance.sort(key=lambda x: x["distance"])
    
    return plumbers_with_distance


