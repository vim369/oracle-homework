package lt.homework.oraclehomework.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import lt.homework.oraclehomework.repository.PiRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PiServiceTest {
    @Mock PiRepository repository;
    @InjectMocks PiService service;

    @Test
    void returnsCalculatedValue() {
        when(repository.calculate(1000)).thenReturn(new BigDecimal("3.140592653839794"));
        assertThat(service.calculate(1000).precision()).isEqualTo(1000);
    }

    @Test
    void rejectsInvalidPrecision() {
        assertThatThrownBy(() -> service.calculate(0))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
