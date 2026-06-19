package LeNhatTruong.authapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private Long id;
    private String name;
    private String email;
    private List<String> roles;
    private String dateOfBirth;
    private Boolean salesNotification;
    private Boolean newArrivalsNotification;
    private Boolean deliveryStatusNotification;
}
