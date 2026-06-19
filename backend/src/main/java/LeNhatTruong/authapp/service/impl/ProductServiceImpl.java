package LeNhatTruong.authapp.service.impl;

import LeNhatTruong.authapp.entity.Category;
import LeNhatTruong.authapp.entity.Product;
import LeNhatTruong.authapp.entity.Tag;
import LeNhatTruong.authapp.repository.CategoryRepository;
import LeNhatTruong.authapp.repository.ProductRepository;
import LeNhatTruong.authapp.repository.TagRepository;
import LeNhatTruong.authapp.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final TagRepository tagRepository;
    private final CategoryRepository categoryRepository;

    @Override
    public List<Product> getSaleProducts() {
        return productRepository.findSaleProducts();
    }

    @Override
    public List<Product> getNewProducts() {
        List<Product> newProducts = productRepository.findByTagsTagNameIgnoreCase("NEW");
        List<Product> nonSaleNew = newProducts.stream()
                .filter(p -> p.getComparePrice() == null || p.getComparePrice() <= p.getSalePrice())
                .toList();
        if (nonSaleNew.isEmpty()) {
            List<Product> allProducts = productRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
            return allProducts.stream()
                    .filter(p -> p.getComparePrice() == null || p.getComparePrice() <= p.getSalePrice())
                    .toList();
        }
        return nonSaleNew;
    }

    @Override
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @Override
    public List<Product> getProductsByTag(String tagName) {
        return productRepository.findByTagsTagNameIgnoreCase(tagName);
    }

    @Override
    @Transactional
    public Product createProduct(Product product) {
        if (productRepository.findByProductName(product.getProductName()).isPresent()) {
            throw new RuntimeException("Product with name '" + product.getProductName() + "' already exists!");
        }

        String slug = product.getProductName().toLowerCase()
                .replaceAll("[^a-z0-9\\s]", "")
                .replaceAll("\\s+", "-");
        product.setSlug(slug);
        product.setPublished(true);
        if (product.getRatingAverage() == null) {
            product.setRatingAverage(5.0);
        }
        if (product.getReviewCount() == null) {
            product.setReviewCount(0);
        }

        if (product.getTagNames() != null) {
            Set<Tag> tags = new HashSet<>();
            for (String tagName : product.getTagNames()) {
                Tag tag = tagRepository.findByTagName(tagName.toUpperCase())
                        .orElseGet(() -> tagRepository.save(Tag.builder().tagName(tagName.toUpperCase()).build()));
                tags.add(tag);
            }
            product.setTags(tags);
        }

        if (product.getCategoryIds() != null) {
            Set<Category> categories = new HashSet<>();
            for (UUID catId : product.getCategoryIds()) {
                categoryRepository.findById(catId).ifPresent(categories::add);
            }
            product.setCategories(categories);
        }

        return productRepository.save(product);
    }

    @Override
    @Transactional
    public Product updateProduct(UUID id, Product input) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id " + id));

        if (input.getProductName() != null) {
            if (!product.getProductName().equalsIgnoreCase(input.getProductName()) &&
                    productRepository.findByProductName(input.getProductName()).isPresent()) {
                throw new RuntimeException("Product with name '" + input.getProductName() + "' already exists!");
            }
            product.setProductName(input.getProductName());
            product.setSlug(input.getProductName().toLowerCase()
                    .replaceAll("[^a-z0-9\\s]", "")
                    .replaceAll("\\s+", "-"));
        }
        if (input.getBrandName() != null) {
            product.setBrandName(input.getBrandName());
        }
        if (input.getImageUrl() != null) {
            product.setImageUrl(input.getImageUrl());
        }
        product.setSalePrice(input.getSalePrice());
        if (input.getComparePrice() != null) {
            product.setComparePrice(input.getComparePrice());
        }
        if (input.getShortDescription() != null) {
            product.setShortDescription(input.getShortDescription());
        }
        if (input.getProductDescription() != null) {
            product.setProductDescription(input.getProductDescription());
        }
        product.setQuantity(input.getQuantity());
        if (input.getProductType() != null) {
            product.setProductType(input.getProductType());
        }
        if (input.getSizes() != null) {
            product.getSizes().clear();
            product.getSizes().addAll(input.getSizes());
        }
        if (input.getColors() != null) {
            product.getColors().clear();
            product.getColors().addAll(input.getColors());
        }

        if (input.getTagNames() != null) {
            Set<Tag> updatedTags = new HashSet<>();
            for (String tagName : input.getTagNames()) {
                Tag tag = tagRepository.findByTagName(tagName.toUpperCase())
                        .orElseGet(() -> {
                            Tag newTag = Tag.builder().tagName(tagName.toUpperCase()).build();
                            return tagRepository.save(newTag);
                        });
                updatedTags.add(tag);
            }
            product.setTags(updatedTags);
        }

        if (input.getCategoryIds() != null) {
            Set<Category> categories = new HashSet<>();
            for (UUID catId : input.getCategoryIds()) {
                categoryRepository.findById(catId).ifPresent(categories::add);
            }
            product.setCategories(categories);
        }

        return productRepository.save(product);
    }

    @Override
    @Transactional
    public void deleteProduct(UUID id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id " + id));
        productRepository.delete(product);
    }

    @Override
    public List<Product> getProductsByCategory(UUID categoryId) {
        return productRepository.findByCategoryId(categoryId);
    }

    @Override
    public java.util.Optional<Product> getProductById(UUID id) {
        return productRepository.findById(id);
    }
}
