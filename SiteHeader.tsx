import Link from "next/link";
export default function SiteHeader(){
 return <header className="wrap"><nav className="nav"><Link className="brand" href="/"><span className="brand-mark">P</span><span>Piring Seimbang</span></Link><div className="navlinks"><Link className="hide-mobile" href="/#program">Program</Link><Link className="hide-mobile" href="/#contoh">Contoh Menu</Link><Link href="/member">Member</Link><Link className="button small" href="/masuk">Masuk</Link></div></nav></header>;
}
