package LeNhatTruong.authapp.mapper;

import LeNhatTruong.authapp.entity.User;
import LeNhatTruong.authapp.entity.Role;
import LeNhatTruong.authapp.dto.response.UserDTO;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;
import java.util.Collections;

@Component
public class UserMapper {

    public UserDTO toDTO(User user) {
        if (user == null) {
            return null;
        }
        return UserDTO.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .roles(user.getRoles() != null
                        ? user.getRoles().stream().map(Role::getName).collect(Collectors.toList())
                        : Collections.emptyList())
                .avatarUrl(user.getAvatarUrl())
                .dateOfBirth(user.getDateOfBirth())
                .salesNotification(user.getSalesNotification())
                .newArrivalsNotification(user.getNewArrivalsNotification())
                .deliveryStatusNotification(user.getDeliveryStatusNotification())
                .build();
    }
}
