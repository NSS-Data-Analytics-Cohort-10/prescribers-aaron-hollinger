SELECT *
FROM CBSA
LIMIT 5

-- 1. 
-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS sum_claim
FROM prescription
GROUP BY npi
ORDER BY sum_claim DESC

--Answer: NPI 1881634483, total number of claimes 99707

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS sum_claim
FROM prescription
LEFT JOIN prescriber
USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY sum_claim DESC

--Answer: Bruce Pendley, Family Practice, total number of claims is 99707

2. 
-- a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS sum_claim
FROM prescription
LEFT JOIN prescriber
USING (npi)
GROUP BY specialty_description
ORDER BY sum_claim DESC

--Answer: Family Practice

--- b. Which specialty had the most total number of claims for opioids?

    c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

    d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

3. 
-- a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, ROUND(total_drug_cost, 0)
FROM prescription
LEFT JOIN drug
USING (drug_name)
ORDER BY total_drug_cost DESC

SELECT generic_name, SUM(total_drug_cost) AS sum_total_cost
FROM prescription
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY sum_total_cost DESC

--ANSWER: INSULIN GLARGINE,HUM.REC.ANLOG

    b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(SUM((total_drug_cost) / 365),2) AS sum_total_cost_per_day
FROM prescription
LEFT JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY sum_total_cost_per_day DESC

--ANSWER: INSULIN GLARGINE,HUM.REC.ANLOG

4. 
-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
	
SELECT drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug
LEFT JOIN prescription
USING (drug_name)

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type,
CAST(SUM(total_drug_cost) AS MONEY) AS sum_cost
FROM drug
LEFT JOIN prescription
USING (drug_name)
GROUP BY
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END

--Answer: More money was spent on opioids.

5. 
-- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT state, COUNT(cbsa) AS count_cbsa
FROM cbsa
LEFT JOIN fips_county
USING (fipscounty)
WHERE state = 'TN'
GROUP BY state

--Answer: 42

-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	
SELECT cbsaname, population
FROM cbsa
LEFT JOIN population
USING (fipscounty)
ORDER BY population ASC

SELECT cbsaname, SUM(population) AS sum_population
FROM cbsa
LEFT JOIN fips_county
USING (fipscounty)
LEFT JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY sum_population ASC

-- Answer: Largest is Nashville-Davidson--Murfreesboro--Franklin, TN, smallest is Morristown, TN

-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, cbsa, SUM(population) AS sum_population
FROM fips_county
LEFT JOIN cbsa
USING (fipscounty)
LEFT JOIN population
USING (fipscounty)
WHERE cbsa IS NULL
GROUP BY county, cbsa
ORDER BY sum_population ASC

--Answer: Largest is Sevier, smallest is Pickett

SELECT county, cbsa, population
FROM fips_county
LEFT JOIN cbsa
USING (fipscounty)
LEFT JOIN population
USING (fipscounty)
WHERE cbsa IS NULL
GROUP BY county, cbsa, population
ORDER BY population ASC

6. 
-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
	
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000

    c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
	
SELECT drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
																							 SELECT prescriber.npi, drug_name, COALESCE(total_claim_count, 0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (drug_name, npi)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug_name, total_claim_count

-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT prescriber.npi, drug_name, COALESCE(total_claim_count, 0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (drug_name, npi)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug_name, total_claim_count




