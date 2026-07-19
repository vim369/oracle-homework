package lt.homework.oraclehomework.api;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record PiRequest(
        @NotNull @Min(1) @Max(1_000) Integer precision
) { }
