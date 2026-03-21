const response = await fetch("http://localhost:8080/api/flags/upsert", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    configID: "747C9E30-0855-4051-B78B-1BF2FEE8A861",
    flagID: "3DC8747B-E60C-4DD2-AE68-80898A8E166E",
    enabled: true,
  }),
})

if (response.ok) {
  console.log("success!")
} else {
  console.error("nope")
  console.log(await response.text())
}