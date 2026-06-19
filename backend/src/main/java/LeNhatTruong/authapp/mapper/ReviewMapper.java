package LeNhatTruong.authapp.mapper;

import LeNhatTruong.authapp.entity.Review;
import LeNhatTruong.authapp.dto.response.ReviewDTO;
import LeNhatTruong.authapp.dto.request.ReviewRequest;
import org.springframework.stereotype.Component;

import java.util.ArrayList;

@Component
public class ReviewMapper {

    public ReviewDTO toDTO(Review review) {
        if (review == null) {
            return null;
        }
        return ReviewDTO.builder()
                .id(review.getId())
                .userId(review.getUser() != null ? review.getUser().getId() : null)
                .name(review.getReviewerName())
                .avatar(review.getReviewerAvatar())
                .avatarUrl(review.getReviewerAvatarUrl())
                .date(review.getReviewDate())
                .title(review.getTitle())
                .content(review.getContent())
                .rating(review.getRating())
                .photos(review.getPhotos() != null ? new ArrayList<>(review.getPhotos()) : new ArrayList<>())
                .helpful(review.isHelpful())
                .hasPhoto(review.hasPhoto())
                .productId(review.getProduct() != null ? review.getProduct().getId().toString() : null)
                .productName(review.getProduct() != null ? review.getProduct().getProductName() : null)
                .productImageUrl(review.getProduct() != null ? review.getProduct().getImageUrl() : null)
                .build();
    }

    public Review toEntity(ReviewRequest request) {
        if (request == null) {
            return null;
        }
        return Review.builder()
                .title(request.getTitle())
                .content(request.getContent())
                .rating(request.getRating())
                .photos(request.getPhotos() != null ? new ArrayList<>(request.getPhotos()) : new ArrayList<>())
                .build();
    }
}
