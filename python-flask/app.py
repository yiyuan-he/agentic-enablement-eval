from flask import Flask, jsonify
import boto3
import os
from botocore.exceptions import ClientError

app = Flask(__name__)

PORT = int(os.environ.get('PORT', 5000))
SERVICE_NAME = os.environ.get('SERVICE_NAME', 'python-flask-app')

s3_client = boto3.client('s3')

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': SERVICE_NAME,
    })

@app.route('/api/buckets')
def list_buckets():
    """List S3 buckets - demonstrates AWS SDK instrumentation"""
    try:
        response = s3_client.list_buckets()
        buckets = [bucket['Name'] for bucket in response.get('Buckets', [])]

        return jsonify({
            'bucket_count': len(buckets),
            'buckets': buckets
        })
    except ClientError as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    print(f"Starting {SERVICE_NAME} on port {PORT}")
    app.run(host="0.0.0.0", port=PORT)
