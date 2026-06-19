package LeNhatTruong.authapp.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;

import LeNhatTruong.authapp.entity.Product;
import LeNhatTruong.authapp.entity.Review;
import LeNhatTruong.authapp.entity.User;
import LeNhatTruong.authapp.repository.ProductRepository;
import LeNhatTruong.authapp.repository.ReviewRepository;
import LeNhatTruong.authapp.service.ReviewService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;

    @Override
    public Map<String, Object> getRatingSummaryForProduct(UUID productId) {
        List<Review> reviews = reviewRepository.findByProductId(productId);
        
        int totalRatings = reviews.size();
        Map<String, Object> response = new HashMap<>();
        if (totalRatings == 0) {
            Map<Integer, Integer> emptyCounts = new HashMap<>();
            for (int i = 1; i <= 5; i++) emptyCounts.put(i, 0);
            response.put("averageRating", 0.0);
            response.put("totalRatings", 0);
            response.put("ratingsCount", emptyCounts);
            return response;
        }

        double sum = 0;
        Map<Integer, Integer> counts = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            counts.put(i, 0);
        }

        for (Review review : reviews) {
            int r = review.getRating();
            sum += r;
            counts.put(r, counts.getOrDefault(r, 0) + 1);
        }

        double average = sum / totalRatings;
        average = Math.round(average * 10.0) / 10.0;

        response.put("averageRating", average);
        response.put("totalRatings", totalRatings);
        response.put("ratingsCount", counts);
        return response;
    }

    @Override
    public List<Review> getReviewsForProduct(UUID productId) {
        return reviewRepository.findByProductId(productId);
    }

    @Override
    public Review createReview(UUID productId, User user, Review review) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm"));

        java.util.Optional<Review> existingOpt = reviewRepository.findByProductIdAndUserId(productId, user.getId());
        if (existingOpt.isPresent()) {
            Review existing = existingOpt.get();
            existing.setTitle(review.getTitle());
            existing.setContent(review.getContent());
            existing.setRating(review.getRating());
            if (review.getPhotos() != null) {
                existing.setPhotos(review.getPhotos());
            } else {
                existing.setPhotos(new ArrayList<>());
            }
            existing.setUpdatedAt(java.time.OffsetDateTime.now());
            return reviewRepository.save(existing);
        }

        review.setUser(user);
        review.setProduct(product);
        if (review.getPhotos() == null) {
            review.setPhotos(new ArrayList<>());
        }
        review.setCreatedAt(java.time.OffsetDateTime.now());
        review.setUpdatedAt(java.time.OffsetDateTime.now());
        return reviewRepository.save(review);
    }

    @Override
    public List<Review> getReviewsForUser(User user) {
        return reviewRepository.findByUserId(user.getId());
    }
}
