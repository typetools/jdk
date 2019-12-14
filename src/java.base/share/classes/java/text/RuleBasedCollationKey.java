/*
 * Copyright (c) 2005, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

/*
 * (C) Copyright Taligent, Inc. 1996 - All Rights Reserved
 * (C) Copyright IBM Corp. 1996 - All Rights Reserved
 *
 *   The original version of this source code and documentation is copyrighted
 * and owned by Taligent, Inc., a wholly-owned subsidiary of IBM. These
 * materials are provided under terms of a License Agreement between Taligent
 * and Sun. This technology is protected by multiple US and International
 * patents. This notice and attribution to Taligent may not be removed.
 *   Taligent is a registered trademark of Taligent, Inc.
 *
 */

package java.text;

import org.checkerframework.checker.nullness.qual.EnsuresNonNullIf;
import org.checkerframework.checker.nullness.qual.NonNull;
import org.checkerframework.checker.nullness.qual.Nullable;
import org.checkerframework.dataflow.qual.Pure;
import org.checkerframework.dataflow.qual.SideEffectFree;

/**
 * A RuleBasedCollationKey is a concrete implementation of CollationKey class.
 * The RuleBasedCollationKey class is used by the RuleBasedCollator class.
 */

final class RuleBasedCollationKey extends CollationKey {
    /**
     * Compare this RuleBasedCollationKey to target. The collation rules of the
     * Collator object which created these keys are applied. <strong>Note:</strong>
     * RuleBasedCollationKeys created by different Collators can not be compared.
     * @param target target RuleBasedCollationKey
     * @return Returns an integer value. Value is less than zero if this is less
     * than target, value is zero if this and target are equal and value is greater than
     * zero if this is greater than target.
     * @see java.text.Collator#compare
     */
    public int compareTo(CollationKey target)
    {
        int result = key.compareTo(((RuleBasedCollationKey)(target)).key);
        if (result <= Collator.LESS)
            return Collator.LESS;
        else if (result >= Collator.GREATER)
            return Collator.GREATER;
        return Collator.EQUAL;
    }

    /**
     * Compare this RuleBasedCollationKey and the target for equality.
     * The collation rules of the Collator object which created these keys are applied.
     * <strong>Note:</strong> RuleBasedCollationKeys created by different Collators can not be
     * compared.
     * @param target the RuleBasedCollationKey to compare to.
     * @return Returns true if two objects are equal, false otherwise.
     */
    @Pure
    @EnsuresNonNullIf(expression="#1", result=true)
    public boolean equals(@Nullable Object target) {
        if (this == target) return true;
        if (target == null || !getClass().equals(target.getClass())) {
            return false;
        }
        RuleBasedCollationKey other = (RuleBasedCollationKey)target;
        return key.equals(other.key);
    }

    /**
     * Creates a hash code for this RuleBasedCollationKey. The hash value is calculated on the
     * key itself, not the String from which the key was created.  Thus
     * if x and y are RuleBasedCollationKeys, then x.hashCode(x) == y.hashCode() if
     * x.equals(y) is true.  This allows language-sensitive comparison in a hash table.
     * See the CollatinKey class description for an example.
     * @return the hash value based on the string's collation order.
     */
    public int hashCode() {
        return (key.hashCode());
    }

    /**
     * Converts the RuleBasedCollationKey to a sequence of bits. If two RuleBasedCollationKeys
     * could be legitimately compared, then one could compare the byte arrays
     * for each of those keys to obtain the same result.  Byte arrays are
     * organized most significant byte first.
     */
    public byte[] toByteArray() {

        char[] src = key.toCharArray();
        byte[] dest = new byte[ 2*src.length ];
        int j = 0;
        for( int i=0; i<src.length; i++ ) {
            dest[j++] = (byte)(src[i] >>> 8);
            dest[j++] = (byte)(src[i] & 0x00ff);
        }
        return dest;
    }

    /**
     * A RuleBasedCollationKey can only be generated by Collator objects.
     */
    RuleBasedCollationKey(String source, String key) {
        super(source);
        this.key = key;
    }
    private String key = null;

}
