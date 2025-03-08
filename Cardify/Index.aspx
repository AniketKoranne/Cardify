<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="Cardify.Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Lobster&family=Montserrat:wght@400;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <link rel="stylesheet" href="CSS/style.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <title>Cardify</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div class="nav-container">
                <nav>
                    <h1 id="logo"></h1>
                    <ul>
                        <li>
                            <%--<asp:LinkButton ID="btnDownload" runat="server" AutoPostBack="false" CssClass="badge badge-pill badge-light p-3" OnClick="btnDownload_Click">Download</asp:LinkButton></li>--%>
                            <asp:LinkButton ID="btnDownload" runat="server" CssClass="badge badge-pill badge-light p-3"
                                OnClientClick="downloadQRCode(); return false;">Download</asp:LinkButton>
                        <li>
                            <asp:LinkButton ID="btnPrint" runat="server" AutoPostBack="false" CssClass="badge badge-pill badge-danger order" OnClientClick="printWiFiCard(); return false;">Print</asp:LinkButton>

                    </ul>
                </nav>
            </div>
            <section class="home">
                <div class="col-md-12" >                    
                    <div class="row mt-5">
                        <div class="col-md-4">
                            <h2 class="p-5 align-items-center">Cardify</h2>
                        </div>
                        <div class="col-md-4">
                            <div class="test align-items-center mt-5">
                                <formview class="justify-contenet-center">
                                    <asp:Label ID="Label1" runat="server" CssClass="mt-5" Text="Network Name"></asp:Label>
                                    <asp:TextBox ID="txtSSID" runat="server" CssClass="form-control mb-5" placeholder="Enter Network Name or SSID"></asp:TextBox>
                                    <asp:Label ID="Label2" runat="server" CssClass="mt-5" Text="Password"></asp:Label>
                                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control mb-5" placeholder="Enter Password"></asp:TextBox>
                                    <asp:Label ID="Label3" runat="server" CssClass="mt-5" Text="Encryption"></asp:Label>

                                    <asp:RadioButtonList ID="rbEncryption" runat="server" CssClass="mt-5">
                                        <asp:ListItem Value="WEP">WEP</asp:ListItem>
                                        <asp:ListItem Value="WPA">WPA (WPA-Personal)</asp:ListItem>
                                        <asp:ListItem Value="WPA2">WPA2 (WPA2-Personal)</asp:ListItem>
                                        <asp:ListItem Value="WPA3">WPA3 (WPA3-Personal)</asp:ListItem>
                                        <asp:ListItem Value="None">None (Open Network)</asp:ListItem>
                                    </asp:RadioButtonList>
                                </formview>
                                
                            </div>
                        </div>
                        <div class="col-md-4">
                            <%--<div id="qrcode" class="p-2" style="background: white;"></div>--%>
                            <div class="wifi-card">
                                <div class="wifi-header">
                                    <img src="img/logo.png" alt="Cardify Logo" class="wifi-logo">
                                    <h3>Cardify</h3>
                                </div>
                                <div id="qrcode"></div>
                                <div class="alert alert-info mt-3">
                                    <strong>Usage tips:</strong>
                                    <ul>
                                        <li>Ensure device WiFi is enabled</li>
                                        <li>Position QR code within camera frame</li>
                                        <li>For WPA3, ensure device compatibility</li>
                                    </ul>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
                                                                                
                
            </section>
        </div>
    </form>
    <footer>
        <h1>Cardify Wifi Cards Generator</h1>
        <ul>
            <li>
                <a href="#">
                    <img src="img/yt-logo.png" alt="" /></a>
            </li>
            <li>
                <a href="#">
                    <img src="img/twitter-logo.png" alt="" /></a>
            </li>
            <li>
                <a href="#">
                    <img src="img/instagram-logo.png" alt="" /></a>
            </li>
        </ul>
    </footer>
    <script>
        // Initialize QR Code
        let qr = new QRCode(document.getElementById("qrcode"), {
            text: "WIFI:S:;T:nopass;;", // Default empty QR code for open network
            width: 200,
            height: 200
        });

        // Function to sanitize SSID & Password
        function escapeText(text) {
            return text.replace(/([\\";:,])/g, '\\$1');
        }


        // Function to generate WiFi QR Code

        function validateInputs() {
            let encryption = document.querySelector('input[name="<%= rbEncryption.ClientID %>"]:checked').value;
            let password = document.getElementById("<%= txtPassword.ClientID %>").value;

            if (encryption === "WEP" && (password.length !== 5 || password.length !== 13)) {
                alert("WEP key must be 5 or 13 characters!");
                return false;
            }
            return true;
        }

        // Attach validation to input events
        document.getElementById("<%= txtPassword.ClientID %>").addEventListener("input", validateInputs);

        function updateQRCode() {
            let ssid = escapeText(document.getElementById("<%= txtSSID.ClientID %>").value.trim());
            let password = escapeText(document.getElementById("<%= txtPassword.ClientID %>").value.trim());

            let encryption = "nopass";
            let encryptionRadios = document.getElementsByName("<%= rbEncryption.ClientID %>");
            for (let i = 0; i < encryptionRadios.length; i++) {
                if (encryptionRadios[i].checked) {
                    encryption = encryptionRadios[i].value;
                    break;
                }
            }

            // Handle 'None' selection for open networks
            if (encryption === "None") {
                encryption = "nopass";
                password = "";
            }

            // Build QR code text
            let qrText;
            if (encryption === "nopass") {
                qrText = `WIFI:S:${ssid};T:${encryption};;`;
            } else {
                qrText = `WIFI:S:${ssid};T:${encryption};P:${password};;`;
            }

            console.log("QR Code Text:", qrText);
            qr.clear();
            qr.makeCode(qrText);
        }

        // Attach Event Listeners for real-time updates
        document.getElementById("<%= txtSSID.ClientID %>").addEventListener("input", updateQRCode);
        document.getElementById("<%= txtPassword.ClientID %>").addEventListener("input", updateQRCode);

        let encryptionRadios = document.getElementsByName("<%= rbEncryption.ClientID %>");
        for (let i = 0; i < encryptionRadios.length; i++) {
            encryptionRadios[i].addEventListener("change", updateQRCode);
        }

    </script>    
    <%--<script>
        function printWiFiCard() {
            let wifiCard = document.querySelector(".wifi-card"); // Select the entire WiFi card

            if (!wifiCard) {
                alert("WiFi Card not found! Please enter network details.");
                return;
            }

            let printWindow = window.open("", "_blank");
            printWindow.document.write(`
            <html>
            <head>
                <title>Print WiFi Card</title>
                <link rel="stylesheet" href="CSS/style.css"> <!-- Ensure styles are applied -->
                <style>
                    body { text-align: left; padding: 20px; }
                    .wifi-card { display: inline-block; padding: 20px; border: 1px solid #ccc; box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.1); }
                </style>
            </head>
            <body onload="window.print(); window.close();">
                ${wifiCard.outerHTML} <!-- Insert the WiFi card into the new window -->
            </body>
            </html>
        `);
            printWindow.document.close();
        }
    </script>--%>
    <script>
        function printWiFiCard() {
            let wifiCard = document.querySelector(".wifi-card"); // Select the WiFi card

            if (!wifiCard) {
                alert("WiFi Card not found! Please enter network details.");
                return;
            }

            let copies = prompt("Enter number of copies to print:", "1"); // Ask user for copies
            copies = parseInt(copies, 10); // Convert input to integer

            if (isNaN(copies) || copies <= 0) {
                alert("Invalid number of copies!");
                return;
            }

            let printWindow = window.open("", "_blank");
            printWindow.document.write(`
            <html>
            <head>
                <title>Print WiFi Cards</title>
                <link rel="stylesheet" href="CSS/style.css"> <!-- Ensure styles apply -->
                <style>
                    body { margin: 0; padding: 0; }
                    .page { 
                        display: grid; 
                        grid-template-columns: repeat(2, 1fr); /* 2 cards per row */
                        grid-template-rows: repeat(2, auto); /* 2 rows per page */
                        gap: 20px; /* Space between cards */
                        width: 100%;
                        page-break-after: always; /* Forces new page after 4 cards */
                    }
                    .wifi-card {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        padding: 20px;
                        border: 1px solid #ccc;
                        box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.1);
                        width: 90%;
                        margin: auto;
                    }
                </style>
            </head>
            <body onload="window.print(); window.close();">
        `);

            // Generate multiple copies of the WiFi card in groups of 4 per page
            for (let i = 0; i < copies; i++) {
                if (i % 4 === 0) printWindow.document.write(`<div class="page">`); // Start a new page every 4 cards
                printWindow.document.write(wifiCard.outerHTML);
                if ((i + 1) % 4 === 0 || i === copies - 1) printWindow.document.write(`</div>`); // Close page after 4 cards or last card
            }

            printWindow.document.write(`</body></html>`);
            printWindow.document.close();
        }
    </script>

    <script>
        function downloadQRCode() {
            let wifiCard = document.querySelector(".wifi-card"); // Select the entire WiFi card

            if (!wifiCard) {
                alert("WiFi Card not found! Please enter network details.");
                return;
            }

            html2canvas(wifiCard, { scale: 2, backgroundColor: null }).then(canvas => {
                let link = document.createElement("a");
                link.href = canvas.toDataURL("image/png");
                link.download = "wifi_card.png";
                link.click();
            });
        }
    </script>


</body>
</html>
