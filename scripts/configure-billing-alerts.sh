#!/bin/bash

echo "Setting up billing alerts for AI Practitioner practice..."

aws cloudwatch put-metric-alarm \
    --alarm-name "AI-Practice-Billing-Alert" \
    --alarm-description "Alert when estimated charges exceed $10" \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 86400 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=Currency,Value=USD \
    --evaluation-periods 1 \
    --alarm-actions arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:billing-alerts

echo "✅ Billing alert configured"
