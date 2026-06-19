package LeNhatTruong.authapp.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WishlistId implements Serializable {
    private Long userId;
    private java.util.UUID productId;
}
