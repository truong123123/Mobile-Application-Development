package LeNhatTruong.authapp.service;

import LeNhatTruong.authapp.entity.Wishlist;
import LeNhatTruong.authapp.entity.WishlistId;
import java.util.List;
import java.util.Optional;

public interface WishlistService {
    List<Wishlist> getAllWishlists();
    Optional<Wishlist> getWishlistById(WishlistId id);
    Wishlist saveWishlist(Wishlist wishlist);
    Wishlist updateWishlist(Wishlist wishlist);
    void deleteWishlist(WishlistId id);

    List<Wishlist> getWishlistByUserId(Long userId);
    Wishlist addToWishlist(Long userId, java.util.UUID productId);
    void removeFromWishlist(Long userId, java.util.UUID productId);
    boolean isInWishlist(Long userId, java.util.UUID productId);
}
