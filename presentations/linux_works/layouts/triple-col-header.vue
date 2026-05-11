<!-- 
Usage: 
´´´md
---
layout: triple-col-header
---

::header::
# Header

::triple-1::
# Triple 1


::triple-2::
# Triple 2


::triple-3::
# Triple 3

´´´
-->



<script setup lang="ts">
const props = defineProps({
    class: {
        type: String,
    },
    layoutClass: {
        type: String,
    },
})
</script>

<template>
    <div class="slidev-layout">
        <div class="col-header">
            <slot name="header" />
        </div>
        <div class="mt-5 mb-5 triple grid grid-cols-3 gap-4 w-full h-4/5" :class="props.layoutClass">
            <div class="col col-1">
                <slot name="triple-1" />
            </div>
            <div class="col col-2">
                <slot name="triple-2" />
            </div>
            <div class="col col-3">
                <slot name="triple-3" />
            </div>
        </div>
    </div>
</template>

<style>
.col {
    display: flexbox;
    flex-direction: column;
    justify-content: flex-start;
    border-right: solid 1px lightseagreen;
}

.col:last-of-type {
    border-right: none;
}

.col-header {
    border-bottom: 1px solid lightseagreen;
    grid-column: 1 / -1;
    height: 5rem;
}
</style>