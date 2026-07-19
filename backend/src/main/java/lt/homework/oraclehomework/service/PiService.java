package lt.homework.oraclehomework.service;

import lt.homework.oraclehomework.api.PiResponse;
import lt.homework.oraclehomework.repository.PiRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PiService {
    private final PiRepository repository;

    public PiService(PiRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public PiResponse calculate(int precision) {
        if (precision < 1 || precision > 1_000) {
            throw new IllegalArgumentException("Precision must be between 1 and 1000");
        }
        return new PiResponse(precision, repository.calculate(precision));
    }
}
