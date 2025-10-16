package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        String serviceName = System.getenv().getOrDefault("SERVICE_NAME", "java-springboot-app");
        String port = System.getenv().getOrDefault("PORT", "8080");

        System.out.println("Starting " + serviceName + " on port " + port);

        System.setProperty("server.port", port);
        SpringApplication.run(Application.class, args);
    }
}
