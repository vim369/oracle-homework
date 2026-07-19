package lt.homework.oraclehomework.controller;

import lt.homework.oraclehomework.api.AgeResponse;
import lt.homework.oraclehomework.service.AgeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ages")
public class AgeController {
    private final AgeService service;

    public AgeController(AgeService service) {
        this.service = service;
    }

    @GetMapping("/{age}")
    public AgeResponse describe(@PathVariable int age) {
        return service.describe(age);
    }
}
