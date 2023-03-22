export const dropzone = () => {
    return {
        mounted() {

            const update = (e) => {
                var data = e.dataTransfer.getData("text");
                this.pushEvent("dropped", {
                    id: data
                })
            }
            this.el.ondrop = update
        },
    }
}

export const dropped = () => {
    return {
        mounted() {

            const update = (e) => {
                e.dataTransfer.setData("text", e.target.id);
            }
            this.el.ondragstart = update
        },
    }
}

export const queryAds = () => {
    return {
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
            this.el.onchange = update
            this.el.onsubmit = e => {
                e.preventDefault()
                update()
            }
        },
    }
}
