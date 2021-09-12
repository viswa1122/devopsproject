package com.malli.devopsproject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DevopsprojectApplication {

	public static void main(String[] args) {
		SpringApplication.run(DevopsprojectApplication.class, args);
	}

	@GetMapping("/hello/{name}")
	public String welcome(@PathVariable String name ) {
		return "Welcome to Devops Project "+name;
	}

	@GetMapping("/hello")
	public String welcomeMsg() {
		return "Welcome to Devops Project ";
	}

}
