import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Piring Seimbang | Program makan lebih terarah",
  description: "Panduan menu, resep, dan kebiasaan makan sehat dari Piring Seimbang."
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body>{children}</body></html>;
}
