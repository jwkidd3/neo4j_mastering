Fraud claims
MATCH (claim:Claim {type: "Auto"})
MATCH (model:FraudModel {model_type: "Auto Insurance"})
CREATE (claim)-[:SCORED_BY]->(model)

MATCH (claim:Claim)-[:SCORED_BY]->(model:FraudModel)
// Apply model's weights to claim's risk indicators
// Compare against thresholds
SET claim.fraud_score = <calculated score>,
    claim.risk_level = CASE 
      WHEN score > model.high_risk_threshold THEN "HIGH"
      WHEN score > model.medium_risk_threshold THEN "MEDIUM"
      ELSE "LOW"
    END

