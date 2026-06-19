package LeNhatTruong.authapp.service;

import LeNhatTruong.authapp.entity.Review;
import LeNhatTruong.authapp.entity.User;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public interface ReviewService {
    Map<String, Object> getRatingSummaryForProduct(UUID productId);
    List<Review> getReviewsForProduct(UUID productId);
    Review createReview(UUID productId, User user, Review review);
    List<Review> getReviewsForUser(User user);
}
