

queryAds = () => {
    return {
        page() { return this.el.dataset.page },
        mounted() {
            const update = () => {
                form = new FormData(this.el)
                data = Object.fromEntries(form)
                document.getElementById("ads-list").innerHTML = ''
                this.pushEvent("query-ads", {
                    query: {
                        term: data["query[term]"],
                        min_price: data["query[min_price]"],
                        max_price: data["query[max_price]"],
                        category_id: data["query[category_id]"],
                        city: data["query[city]"],
                        state: data["query[state]"]
                    }
                })
            }
            this.el.addEventListener("change", update)
            this.el.addEventListener("submit", (e) => { e.preventDefault(); update(); })
        },
        reconnected() { this.pending = this.page() },
        updated() { this.pending = this.page() }
    }
}

export default queryAds
