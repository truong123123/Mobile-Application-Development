package LeNhatTruong.authapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDTO {
    private Long id;
    private Long userId;
    private String name;
    private String avatar;
    private String avatarUrl;
    private String date;
    private String title;
    private String content;
    private int rating;
    private List<String> photos;
    private boolean helpful;
    private boolean hasPhoto;
    private String productId;
    private String productName;
    private String productImageUrl;
}
