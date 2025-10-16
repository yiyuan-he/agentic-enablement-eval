const express = require('express');
const { S3Client, ListBucketsCommand } = require('@aws-sdk/client-s3');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVICE_NAME = process.env.SERVICE_NAME || 'nodejs-express-app';
const s3Client = new S3Client({});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: SERVICE_NAME
  });
});

app.get('/api/buckets', async (req, res) => {
  try {
    const command = new ListBucketsCommand({});
    const response = await s3Client.send(command);
    const buckets = response.Buckets.map(bucket => bucket.Name);

    res.json({
      bucket_count: buckets.length,
      buckets: buckets
    });
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Starting ${SERVICE_NAME} on port ${PORT}`);
});
