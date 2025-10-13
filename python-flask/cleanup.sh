echo "Destroying AppSignals test stack..."
cd generated/ecs-cdk && cdk destroy --force

echo "Cleaning generated files..."
rm -rf generated/

echo "Cleanup complete. Ready to re-run"
