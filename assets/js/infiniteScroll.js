
infiniteScroll = (scrollAt, el) => {
    return {
        page() { return this.el.dataset.page },
        mounted() {
            el().addEventListener("scroll", _ => {
                if (this.pending == this.page() && (scrollAt() > 90 || scrollAt() < -90)) {
                    this.pending = this.page() + 1
                    this.pushEvent("load-more", {})
                }
            })
        },
        reconnected() { this.pending = this.page() },
        updated() { this.pending = this.page() }
    }
}

export default infiniteScroll
