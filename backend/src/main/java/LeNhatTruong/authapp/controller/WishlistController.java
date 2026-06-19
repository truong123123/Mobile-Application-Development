package LeNhatTruong.authapp.controller;

import LeNhatTruong.authapp.entity.Product;
import LeNhatTruong.authapp.entity.Wishlist;
import LeNhatTruong.authapp.repository.ProductRepository;
import LeNhatTruong.authapp.security.CustomUserDetails;
import LeNhatTruong.authapp.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;
    private final ProductRepository productRepository;

    @GetMapping
    public ResponseEntity<List<Product>> getWishlist(@AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = userDetails.getUser().getId();
        List<Wishlist> wishlistItems = wishlistService.getWishlistByUserId(userId);
        
        List<Product> products = wishlistItems.stream()
                .map(item -> productRepository.findById(item.getProductId()))
                .filter(java.util.Optional::isPresent)
                .map(java.util.Optional::get)
                .collect(Collectors.toList());
                
        return ResponseEntity.ok(products);
    }

    @PostMapping("/{productId}")
    public ResponseEntity<Void> addToWishlist(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID productId) {
        if (userDetails == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = userDetails.getUser().getId();
        wishlistService.addToWishlist(userId, productId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFromWishlist(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable UUID productId) {
        if (userDetails == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = userDetails.getUser().getId();
        wishlistService.removeFromWishlist(userId, productId);
        return ResponseEntity.ok().build();
    }
}
