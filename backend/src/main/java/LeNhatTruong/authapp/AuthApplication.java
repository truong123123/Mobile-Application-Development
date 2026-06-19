package LeNhatTruong.authapp;

import LeNhatTruong.authapp.entity.Role;
import LeNhatTruong.authapp.entity.User;
import LeNhatTruong.authapp.repository.RoleRepository;
import LeNhatTruong.authapp.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.Collections;

@SpringBootApplication
public class AuthApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthApplication.class, args);
    }

    @Bean
    @org.springframework.core.annotation.Order(2)
    @Profile("!test")
    public CommandLineRunner initDatabase(
            UserRepository userRepository,
            RoleRepository roleRepository,
            PasswordEncoder passwordEncoder,
            LeNhatTruong.authapp.repository.OrderRepository orderRepository,
            LeNhatTruong.authapp.repository.CustomerAddressRepository addressRepository,
            LeNhatTruong.authapp.repository.CardRepository cardRepository,
            LeNhatTruong.authapp.repository.CouponRepository couponRepository,
            LeNhatTruong.authapp.repository.ReviewRepository reviewRepository,
            LeNhatTruong.authapp.repository.ProductRepository productRepository,
            LeNhatTruong.authapp.repository.OrderStatusRepository orderStatusRepository,
            LeNhatTruong.authapp.repository.CustomerRepository customerRepository
    ) {
        return args -> {
            Role userRole = roleRepository.findByName("ROLE_USER")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));

            Role adminRole = roleRepository.findByName("ROLE_ADMIN")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_ADMIN").build()));

            if (!userRepository.existsByEmail("truongng1511@gmail.com")) {
                User user = User.builder()
                        .name("truongng1511")
                        .email("truongng1511@gmail.com")
                        .password(passwordEncoder.encode("879779"))
                        .provider("local")
                        .roles(new java.util.HashSet<>(java.util.List.of(userRole, adminRole)))
                        .build();
                userRepository.save(user);
                System.out.println(">>> SEEDED USER WITH ADMIN ROLE: truongng1511@gmail.com / 879779 <<<");
            } else {
                userRepository.findByEmail("truongng1511@gmail.com").ifPresent(user -> {
                    if (user.getRoles().stream().noneMatch(r -> r.getName().equals("ROLE_ADMIN"))) {
                        user.getRoles().add(adminRole);
                        userRepository.save(user);
                        System.out.println(">>> UPGRADED truongng1511@gmail.com TO ROLE_ADMIN <<<");
                    }
                });
            }

            // Seed user profile statistics mock data
            final User dbUser = userRepository.findByEmail("truongng1511@gmail.com").orElse(null);
            if (dbUser != null) {
                final Long userId = dbUser.getId();

                // Get or create Customer for this user
                final String[] names = dbUser.getName().split(" ", 2);
                final String firstName = names[0];
                final String lastName = names.length > 1 ? names[1] : firstName;
                
                final LeNhatTruong.authapp.entity.Customer customer = customerRepository.findByUserId(userId)
                        .orElseGet(() -> customerRepository.save(LeNhatTruong.authapp.entity.Customer.builder()
                                .user(dbUser)
                                .firstName(firstName)
                                .lastName(lastName)
                                .email(dbUser.getEmail())
                                .passwordHash(dbUser.getPassword() != null ? dbUser.getPassword() : "")
                                .active(true)
                                .registeredAt(java.time.OffsetDateTime.now())
                                .updatedAt(java.time.OffsetDateTime.now())
                                .build()));

                // Seed Orders (12 orders) if count is 0
                if (orderRepository.countByCustomerUserId(userId) == 0) {
                    final LeNhatTruong.authapp.entity.OrderStatus defaultStatus = orderStatusRepository.findAll().stream().findFirst()
                            .orElseGet(() -> orderStatusRepository.save(LeNhatTruong.authapp.entity.OrderStatus.builder()
                                    .statusName("Delivered")
                                    .color("#4CAF50")
                                    .createdAt(java.time.OffsetDateTime.now())
                                    .updatedAt(java.time.OffsetDateTime.now())
                                    .build()));

                    for (int i = 1; i <= 12; i++) {
                        final int daysAgo = i;
                        orderRepository.save(LeNhatTruong.authapp.entity.Order.builder()
                                .customer(customer)
                                .createdAt(java.time.OffsetDateTime.now().minusDays(daysAgo))
                                .orderStatus(defaultStatus)
                                .build());
                    }
                    System.out.println(">>> Seeded 12 sample orders for user: " + userId + " <<<");
                }

                // Seed Addresses (3 addresses) if count is 0
                if (addressRepository.countByCustomerUserId(userId) == 0) {
                    addressRepository.save(LeNhatTruong.authapp.entity.CustomerAddress.builder()
                            .customer(customer)
                            .fullName("Jane Doe")
                            .addressLine1("3 Newbridge Court")
                            .city("Chino Hills")
                            .state("California")
                            .country("United States")
                            .postalCode("91709")
                            .phoneNumber("123456789")
                            .dialCode("+1")
                            .isDefault(true)
                            .build());
                    addressRepository.save(LeNhatTruong.authapp.entity.CustomerAddress.builder()
                            .customer(customer)
                            .fullName("John Doe")
                            .addressLine1("3 Newbridge Court")
                            .city("Chino Hills")
                            .state("California")
                            .country("United States")
                            .postalCode("91709")
                            .phoneNumber("987654321")
                            .dialCode("+1")
                            .isDefault(false)
                            .build());
                    addressRepository.save(LeNhatTruong.authapp.entity.CustomerAddress.builder()
                            .customer(customer)
                            .fullName("John Doe")
                            .addressLine1("51 Riverside")
                            .city("Chino Hills")
                            .state("California")
                            .country("United States")
                            .postalCode("91709")
                            .phoneNumber("555123456")
                            .dialCode("+1")
                            .isDefault(false)
                            .build());
                    System.out.println(">>> Seeded 3 sample addresses for user: " + userId + " <<<");
                }

                // Seed Card (1 card: Visa **34) if count is 0
                if (cardRepository.countByCustomerUserId(userId) == 0) {
                    cardRepository.save(LeNhatTruong.authapp.entity.Card.builder()
                            .customer(customer)
                            .cardType("Visa")
                            .lastFour("34")
                            .build());
                    System.out.println(">>> Seeded Visa card for user: " + userId + " <<<");
                }

                // Seed Coupons (5 promocodes) if count is 0
                if (couponRepository.count() == 0) {
                    for (int i = 1; i <= 5; i++) {
                        couponRepository.save(LeNhatTruong.authapp.entity.Coupon.builder()
                                .code("PROMO" + i)
                                .discountType("PERCENTAGE")
                                .discountValue(10.0 + i)
                                .timesUsed(0.0)
                                .maxUsage(1.0)
                                .build());
                    }
                    System.out.println(">>> Seeded 5 promocodes <<<");
                }

                // Seed Reviews (4 reviews) if count is 0
                if (reviewRepository.countByUserId(userId) == 0) {
                    final java.util.List<LeNhatTruong.authapp.entity.Product> products = productRepository.findAll();
                    if (!products.isEmpty()) {
                        for (int i = 1; i <= 4; i++) {
                            final LeNhatTruong.authapp.entity.Product product = (products.size() >= i) ? products.get(i - 1) : products.get(0);
                            reviewRepository.save(LeNhatTruong.authapp.entity.Review.builder()
                                    .user(dbUser)
                                    .product(product)
                                    .content("Sản phẩm rất tốt, giao hàng nhanh " + i)
                                    .rating(5)
                                    .createdAt(java.time.OffsetDateTime.now())
                                    .build());
                        }
                        System.out.println(">>> Seeded 4 product reviews for user: " + userId + " <<<");
                    }
                }
            }
        };
    }
}
