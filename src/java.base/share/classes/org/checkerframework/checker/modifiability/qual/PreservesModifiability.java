package org.checkerframework.checker.modifiability.qual;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * The annotated method preserves modifiability capabilities from its first argument to its return
 * value.
 *
 * <p>For example, if the first argument has a positive modifiability capability, such as
 * {@code @Growable}, {@code @SeqGrowable}, {@code @Shrinkable}, or {@code @Replaceable}, then the
 * return type has that same capability. If the first argument is {@code @IteratorPolyMod}, then the
 * return type is also {@code @IteratorPolyMod}. If the first argument has any other qualifier in a
 * capability hierarchy, then the return type is the top qualifier in that hierarchy.
 *
 * <p>If the annotated method has no parameters or returns {@code void}, then this annotation has no
 * effect on the method.
 *
 * @checker_framework.manual #modifiability-checker Modifiability Checker
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface PreservesModifiability {}
