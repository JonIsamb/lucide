// Tax rules used by the simulator. One constant per rate.
//
// Source of every value: the project brief (section 7.2), valid for sales
// made in 2026. They were not checked against the tax administration
// website: re-check them before using the app for anything but teaching.

/// Flat tax on securities accounts (compte titres) and on cryptos.
/// Effective: 2026.
const securitiesAccountTaxRate = 0.314;

/// PEA held for 5 years or more: social contributions only.
/// Effective: 2026.
const peaAfterFiveYearsTaxRate = 0.186;

/// PEA held for less than 5 years: same rate as the securities account.
/// Effective: 2026.
const peaBeforeFiveYearsTaxRate = 0.314;

/// Cryptos: nothing is due when the sales of the year total this amount
/// or less. The simulation knows one sale only (documented assumption).
/// Effective: 2026.
const cryptoExemptionThresholdEur = 305.0;

/// Years a PEA must be held to get the lower rate.
const peaHoldingYears = 5;
