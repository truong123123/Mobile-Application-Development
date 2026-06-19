package LeNhatTruong.authapp.entity;

import jakarta.persistence.*;
import java.io.Serializable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "wishlist")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(WishlistId.class)
public class Wishlist {
    // Composite Primary Key using WishlistId

    @Id
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Id
    @Column(name = "product_id", nullable = false)
    private java.util.UUID productId;

    @Column(name = "created_at", nullable = false)
    private java.time.OffsetDateTime createdAt;
}
