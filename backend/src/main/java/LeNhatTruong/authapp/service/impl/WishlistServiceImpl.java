package LeNhatTruong.authapp.service.impl;

import LeNhatTruong.authapp.entity.Wishlist;
import LeNhatTruong.authapp.entity.WishlistId;
import LeNhatTruong.authapp.repository.WishlistRepository;
import LeNhatTruong.authapp.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WishlistServiceImpl implements WishlistService {
    private final WishlistRepository wishlistRepository;

    @Override
    public List<Wishlist> getAllWishlists() {
        return wishlistRepository.findAll();
    }

    @Override
    public Optional<Wishlist> getWishlistById(WishlistId id) {
        return wishlistRepository.findById(id);
    }

    @Override
    public Wishlist saveWishlist(Wishlist wishlist) {
        return wishlistRepository.save(wishlist);
    }

    @Override
    public Wishlist updateWishlist(Wishlist wishlist) {
        return wishlistRepository.save(wishlist);
    }

    @Override
    public void deleteWishlist(WishlistId id) {
        wishlistRepository.deleteById(id);
    }

    @Override
    public List<Wishlist> getWishlistByUserId(Long userId) {
        return wishlistRepository.findByUserId(userId);
    }

    @Override
    public Wishlist addToWishlist(Long userId, java.util.UUID productId) {
        if (wishlistRepository.existsByUserIdAndProductId(userId, productId)) {
            return wishlistRepository.findById(new WishlistId(userId, productId)).orElse(null);
        }
        Wishlist item = Wishlist.builder()
                .userId(userId)
                .productId(productId)
                .createdAt(java.time.OffsetDateTime.now())
                .build();
        return wishlistRepository.save(item);
    }

    @Override
    public void removeFromWishlist(Long userId, java.util.UUID productId) {
        wishlistRepository.deleteByUserIdAndProductId(userId, productId);
    }

    @Override
    public boolean isInWishlist(Long userId, java.util.UUID productId) {
        return wishlistRepository.existsByUserIdAndProductId(userId, productId);
    }
}
