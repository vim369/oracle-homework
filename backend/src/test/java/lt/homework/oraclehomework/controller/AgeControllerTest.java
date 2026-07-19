package lt.homework.oraclehomework.controller;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import lt.homework.oraclehomework.api.AgeResponse;
import lt.homework.oraclehomework.service.AgeService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(AgeController.class)
class AgeControllerTest {
    @Autowired MockMvc mvc;
    @MockitoBean AgeService service;

    @Test
    void returnsJson() throws Exception {
        when(service.describe(35)).thenReturn(new AgeResponse(35, "You are adult"));
        mvc.perform(get("/api/ages/35"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.age").value(35))
                .andExpect(jsonPath("$.description").value("You are adult"));
    }
}
