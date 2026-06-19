# Synchronized Wishlist / Favorites System

This plan details the implementation of a database-backed wishlist (favorites) system. When a user is logged in, their favorites will be saved in the backend PostgreSQL database, allowing favorites to persist across devices and logouts. When not logged in, the app will fallback to local offline favorites or prompt login.

## Proposed Changes

### Backend (Spring Boot)

---

#### [MODIFY] [Wishlist.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/entity/Wishlist.java)
- Change the `userId` field type from `UUID` to `Long` to match the primary key type of `User.java`.

#### [MODIFY] [WishlistId.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/entity/WishlistId.java)
- Change the `userId` field type from `UUID` to `Long`.

#### [MODIFY] [WishlistRepository.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/repository/WishlistRepository.java)
- Add custom query methods:
  ```java
  List<Wishlist> findByUserId(Long userId);
  void deleteByUserIdAndProductId(Long userId, java.util.UUID productId);
  boolean existsByUserIdAndProductId(Long userId, java.util.UUID productId);
  ```

#### [MODIFY] [WishlistService.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/service/WishlistService.java) & [WishlistServiceImpl.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/service/impl/WishlistServiceImpl.java)
- Implement wishlist management methods:
  ```java
  List<Wishlist> getWishlistByUserId(Long userId);
  void addToWishlist(Long userId, java.util.UUID productId);
  void removeFromWishlist(Long userId, java.util.UUID productId);
  boolean isInWishlist(Long userId, java.util.UUID productId);
  ```

#### [NEW] [WishlistController.java](file:///d:/LeNhatTruong_32/backend/src/main/java/LeNhatTruong/authapp/controller/WishlistController.java)
- Add REST controller with endpoints:
  - `GET /api/wishlist` - Get wishlist products for the authenticated user.
  - `POST /api/wishlist/{productId}` - Add a product to wishlist.
  - `DELETE /api/wishlist/{productId}` - Delete a product from wishlist.

---

### Frontend (Flutter)

---

#### [MODIFY] [favorites_provider.dart](file:///d:/LeNhatTruong_32/frontend/lib/features/favorites/providers/favorites_provider.dart)
- Update `FavoritesProvider` to:
  - Read JWT token from `SharedPreferences`.
  - Fetch favorites from `GET /api/wishlist` upon login.
  - Send HTTP `POST` to `/api/wishlist/{productId}` when adding a favorite.
  - Send HTTP `DELETE` to `/api/wishlist/{productId}` when removing a favorite.
  - Sync with local `SharedPreferences` as an offline backup.

## Verification Plan

### Automated Tests
- Run `.\mvnw.cmd compile` to verify the backend builds without errors.
- Run `flutter analyze` to ensure Dart files are error-free.

### Manual Verification
- Test adding/removing items from favorites on Android emulator/phone.
- Log out and log back in to verify that the heart states (favorites list) are loaded correctly from the backend database.
- Inspect the PostgreSQL `wishlist` table to ensure rows are inserted/deleted correctly.
