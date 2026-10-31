package su.ronicon
import com.github.javiersantos.piracychecker.PiracyChecker
import dev.jahir.blueprint.ui.activities.BottomNavigationBlueprintActivity

/**
 * You can choose between:
 * - DrawerBlueprintActivity
 * - BottomNavigationBlueprintActivity
 */
class MainActivity : BottomNavigationBlueprintActivity() {

    /**
     * These things here have the default values. You can delete the ones you don't want to change
     * and/or modify the ones you want to.
     */
    override val billingEnabled = false
    override fun amazonInstallsEnabled(): Boolean = false
    override fun checkLPF(): Boolean = false
    override fun checkStores(): Boolean = false
    override fun getLicKey(): String = ""
    override fun getLicenseChecker(): PiracyChecker? { return null }

    override fun defaultTheme(): Int = R.style.MyApp_Default
    override fun amoledTheme(): Int = R.style.MyApp_Default_Amoled
    override fun defaultMaterialYouTheme(): Int = R.style.MyApp_Default_MaterialYou
    override fun amoledMaterialYouTheme(): Int = R.style.MyApp_Default_Amoled_MaterialYou
}
