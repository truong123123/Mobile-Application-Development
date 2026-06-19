package LeNhatTruong.authapp.controller;

import LeNhatTruong.authapp.dto.request.ReviewRequest;
import LeNhatTruong.authapp.dto.response.ReviewDTO;
import LeNhatTruong.authapp.entity.Review;
import LeNhatTruong.authapp.mapper.ReviewMapper;
import LeNhatTruong.authapp.security.CustomUserDetails;
import LeNhatTruong.authapp.service.ReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;
    private final ReviewMapper reviewMapper;

    @GetMapping("/product/{productId}/summary")
    public ResponseEntity<Map<String, Object>> getProductRatingSummary(@PathVariable UUID productId) {
        return ResponseEntity.ok(reviewService.getRatingSummaryForProduct(productId));
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<ReviewDTO>> getProductReviews(@PathVariable UUID productId) {
        List<ReviewDTO> reviews = reviewService.getReviewsForProduct(productId).stream()
                .map(reviewMapper::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reviews);
    }

    @PostMapping("/product/{productId}")
    public ResponseEntity<ReviewDTO> createProductReview(
            @PathVariable UUID productId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody ReviewRequest reviewRequest
    ) {
        if (userDetails == null) {
            return ResponseEntity.status(401).build();
        }
        Review reviewEntity = reviewMapper.toEntity(reviewRequest);
        Review savedReview = reviewService.createReview(productId, userDetails.getUser(), reviewEntity);
        return ResponseEntity.ok(reviewMapper.toDTO(savedReview));
    }

    @GetMapping("/my")
    public ResponseEntity<List<ReviewDTO>> getMyReviews(@AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null) {
            return ResponseEntity.status(401).build();
        }
        List<ReviewDTO> reviews = reviewService.getReviewsForUser(userDetails.getUser()).stream()
                .map(reviewMapper::toDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reviews);
    }
}
