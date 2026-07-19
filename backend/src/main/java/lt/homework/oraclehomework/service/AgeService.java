package lt.homework.oraclehomework.service;

import lt.homework.oraclehomework.api.AgeResponse;
import lt.homework.oraclehomework.repository.AgeRepository;
import org.springframework.stereotype.Service;

@Service
public class AgeService {
    private final AgeRepository repository;

    public AgeService(AgeRepository repository) {
        this.repository = repository;
    }

    public AgeResponse describe(int age) {
        if (age < 0) {
            throw new IllegalArgumentException("Age must be a non-negative integer");
        }
        return new AgeResponse(age, repository.findDescription(age));
    }
}
