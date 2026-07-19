package lt.homework.oraclehomework.controller;

import jakarta.validation.Valid;
import lt.homework.oraclehomework.api.PiRequest;
import lt.homework.oraclehomework.api.PiResponse;
import lt.homework.oraclehomework.service.PiService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/pi")
public class PiController {
    private final PiService service;

    public PiController(PiService service) {
        this.service = service;
    }

    @PostMapping
    public PiResponse calculate(@Valid @RequestBody PiRequest request) {
        return service.calculate(request.precision());
    }
}
