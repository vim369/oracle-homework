package lt.homework.oraclehomework.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import lt.homework.oraclehomework.repository.AgeRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class AgeServiceTest {
    @Mock AgeRepository repository;
    @InjectMocks AgeService service;

    @Test
    void returnsDatabaseDescription() {
        when(repository.findDescription(35)).thenReturn("You are adult");
        assertThat(service.describe(35).description()).isEqualTo("You are adult");
    }

    @Test
    void rejectsNegativeAge() {
        assertThatThrownBy(() -> service.describe(-1))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
