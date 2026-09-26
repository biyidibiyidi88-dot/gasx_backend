"""Shared bottle-size capacity and estimated tare configuration."""

from decimal import Decimal


BOTTLE_CAPACITIES_KG = {
    "SMALL_6KG": Decimal("6.00"),
    "MEDIUM_12_5KG": Decimal("12.50"),
    "BIG_50KG": Decimal("50.00"),
}

# These are starting estimates only. The bottle's stamped tare weight should
# be entered in the user's profile for accurate remaining-gas calculations.
BOTTLE_BASE_TARES_KG = {
    "SMALL_6KG": Decimal("6.50"),
    "MEDIUM_12_5KG": Decimal("12.50"),
    "BIG_50KG": Decimal("48.00"),
}

BOTTLE_BRAND_TARE_OFFSETS_KG = {
    "SCTM": Decimal("1.00"),
    "TOTAL_ENERGIES": Decimal("1.50"),
    "TRADEX": Decimal("2.00"),
    "STAR_GAS": Decimal("2.50"),
    "AZA_MRS": Decimal("0.50"),
}


def bottle_capacity_kg(size, fallback=None):
    """Return the configured LPG capacity for a selected bottle size."""
    return BOTTLE_CAPACITIES_KG.get(size, Decimal(str(fallback or "12.50")))


def estimated_tare_kg(size, brand=""):
    """Return an editable tare estimate, not a substitute for the bottle label."""
    base = BOTTLE_BASE_TARES_KG.get(size, BOTTLE_BASE_TARES_KG["MEDIUM_12_5KG"])
    return base + BOTTLE_BRAND_TARE_OFFSETS_KG.get(brand, Decimal("0.00"))


def user_bottle_capacity_kg(user):
    """Use bottle type as the source of truth; support legacy custom rows."""
    return bottle_capacity_kg(
        getattr(user, "preferred_bottle_size", None),
        getattr(user, "gas_capacity", Decimal("12.50")),
    )
