package com.example;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.Bucket;
import software.amazon.awssdk.services.s3.model.ListBucketsResponse;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
public class ApiController {

    private final S3Client s3Client = S3Client.builder()
        .region(Region.of(System.getenv("AWS_REGION")))
        .build();
    private final String serviceName = System.getenv().getOrDefault("SERVICE_NAME", "java-springboot-app");

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("service", serviceName);
        return response;
    }

    @GetMapping("/api/buckets")
    public Map<String, Object> listBuckets() {
        Map<String, Object> response = new HashMap<>();
        try {
            ListBucketsResponse bucketsResponse = s3Client.listBuckets();
            List<String> buckets = bucketsResponse.buckets().stream()
                .map(Bucket::name)
                .collect(Collectors.toList());

            response.put("bucket_count", buckets.size());
            response.put("buckets", buckets);
        } catch (Exception e) {
            response.put("error", e.getMessage());
        }
        return response;
    }
}
