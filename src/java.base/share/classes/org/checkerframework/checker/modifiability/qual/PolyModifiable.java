package org.checkerframework.checker.modifiability.qual;

import java.lang.annotation.ElementType;
import java.lang.annotation.Target;

/**
 * Convenience alias meaning
 * {@code @PolyGrowable @PolyReplaceable @PolyShrinkable @PolySeqGrowable @PolyIteratorPolyMod}. A
 * polymorphic qualifier for all five modifiability hierarchies.
 *
 * <p>Write {@code @PolyModifiable} on methods that preserve or transfer modifiability, such as
 * {@code List.subList()}.
 *
 * <p>For example:
 *
 * <pre><code>
 * class Example {
 * &nbsp; @PolyModifiable List&lt;E&gt; subList(@PolyModifiable List&lt;E&gt; this, int from, int to);
 * }
 * </code></pre>
 *
 * At each call site, the return type is equal to the receiver type. If the receiver type is
 * {@code @Growable}, the return type is {@code @Growable}. If the receiver type is
 * {@code @Ungrowable}, the return type is {@code @Ungrowable}.
 *
 * @checker_framework.manual #modifiability-checker Modifiability Checker
 * @checker_framework.manual #qualifier-polymorphism Qualifier polymorphism
 */
@Target({ElementType.TYPE_USE, ElementType.TYPE_PARAMETER})
public @interface PolyModifiable {}
