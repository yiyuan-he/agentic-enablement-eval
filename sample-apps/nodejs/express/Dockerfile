FROM node:18-slim

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY . .

ENV PORT=3000
ENV SERVICE_NAME=nodejs-express-app

# Set environment variables for OpenTelemetry
ENV OTEL_METRICS_EXPORTER=none
ENV OTEL_LOGS_EXPORTER=none
ENV OTEL_AWS_APPLICATION_SIGNALS_ENABLED=true
ENV OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
ENV OTEL_TRACES_SAMPLER=xray
ENV OTEL_TRACES_SAMPLER_ARG=endpoint=http://localhost:2000
ENV OTEL_AWS_APPLICATION_SIGNALS_EXPORTER_ENDPOINT=http://localhost:4316/v1/metrics
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4316/v1/traces
ENV OTEL_RESOURCE_ATTRIBUTES=service.name=nodejs-express-app

EXPOSE 3000

# Start application with ADOT instrumentation
CMD ["node", "--require", "@aws/aws-distro-opentelemetry-node-autoinstrumentation/register", "app.js"]
