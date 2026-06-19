package LeNhatTruong.authapp.service;

import LeNhatTruong.authapp.entity.Product;
import java.util.List;
import java.util.UUID;

public interface ProductService {
    List<Product> getSaleProducts();
    List<Product> getNewProducts();
    List<Product> getAllProducts();
    List<Product> getProductsByTag(String tagName);
    Product createProduct(Product product);
    Product updateProduct(UUID id, Product input);
    void deleteProduct(UUID id);
    List<Product> getProductsByCategory(UUID categoryId);
    java.util.Optional<Product> getProductById(UUID id);
}
