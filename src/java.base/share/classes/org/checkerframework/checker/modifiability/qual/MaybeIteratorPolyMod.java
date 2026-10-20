package org.checkerframework.checker.modifiability.qual;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.checkerframework.framework.qual.DefaultQualifierInHierarchy;
import org.checkerframework.framework.qual.SubtypeOf;

/**
 * For the annotated collection, the return type of {@code iterator()} is {@code @MaybeShrinkable}.
 *
 * <p>This is the default qualifier for unannotated types.
 *
 * @see IteratorPolyMod
 * @checker_framework.manual #modifiability-checker Modifiability Checker
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
@SubtypeOf({})
@DefaultQualifierInHierarchy
public @interface MaybeIteratorPolyMod {}
