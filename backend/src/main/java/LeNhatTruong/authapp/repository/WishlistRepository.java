package LeNhatTruong.authapp.repository;

import LeNhatTruong.authapp.entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import LeNhatTruong.authapp.entity.WishlistId;
import java.util.List;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, WishlistId> {
    List<Wishlist> findByUserId(Long userId);

    @Transactional
    void deleteByUserIdAndProductId(Long userId, java.util.UUID productId);

    boolean existsByUserIdAndProductId(Long userId, java.util.UUID productId);
}
