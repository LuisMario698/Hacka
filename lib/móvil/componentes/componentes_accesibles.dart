import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colores accesibles e inclusivos para la aplicación
class ColoresAccesibles {
  // Colores principales con buen contraste
  static const Color seguro = Color(0xFF2E7D32);         // Verde oscuro
  static const Color precaucion = Color(0xFFFF8F00);     // Naranja
  static const Color peligroso = Color(0xFFD32F2F);      // Rojo
  static const Color neutral = Color(0xFF546E7A);        // Gris azulado
  static const Color info = Color(0xFF1976D2);           // Azul información
  
  // Versiones con mayor contraste para personas con discapacidad visual
  static const Color seguroAltoContraste = Color(0xFF1B5E20);
  static const Color peligrosoAltoContraste = Color(0xFFB71C1C);
  static const Color infoAltoContraste = Color(0xFF0D47A1);
  
  // Fondos y superficies
  static const Color fondoClaro = Color(0xFFF5F5F5);
  static const Color fondoOscuro = Color(0xFF121212);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color superficieOscura = Color(0xFF1E1E1E);
  
  // Texto
  static const Color textoPrimario = Color(0xFF212121);
  static const Color textoSecundario = Color(0xFF757575);
  static const Color textoClaro = Color(0xFFFFFFFF);
}

/// Tarjeta accesible estándar para la aplicación
class TarjetaAccesible extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool esGrande;
  final bool habilitada;

  const TarjetaAccesible({
    Key? key,
    required this.titulo,
    this.subtitulo,
    required this.icono,
    required this.color,
    this.onTap,
    this.trailing,
    this.esGrande = false,
    this.habilitada = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final tamanoIcono = esGrande ? 32.0 : 24.0;
    final tamanoTitulo = esGrande ? 20.0 : 16.0;
    
    return Semantics(
      button: onTap != null,
      enabled: habilitada,
      label: titulo,
      hint: subtitulo != null ? subtitulo : 'Toque para más opciones',
      child: Card(
        elevation: habilitada ? 3 : 1,
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: esGrande ? 12 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: habilitada ? () {
            HapticFeedback.lightImpact();
            onTap?.call();
          } : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(esGrande ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(esGrande ? 12 : 8),
                  decoration: BoxDecoration(
                    color: habilitada ? color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icono,
                    color: Colors.white,
                    size: tamanoIcono,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontSize: tamanoTitulo,
                          fontWeight: FontWeight.w600,
                          color: habilitada ? null : Colors.grey.shade600,
                        ),
                      ),
                      if (subtitulo != null) ...[
                        SizedBox(height: 4),
                        Text(
                          subtitulo!,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: habilitada ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: habilitada ? Colors.grey.shade400 : Colors.grey.shade300,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón accesible con tamaños y estilos consistentes
class BotonAccesible extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool esGrande;
  final bool esPrimario;
  final bool expandido;

  const BotonAccesible({
    Key? key,
    required this.texto,
    this.icono,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.esGrande = false,
    this.esPrimario = false,
    this.expandido = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colorFondo = backgroundColor ?? 
        (esPrimario ? ColoresAccesibles.seguro : tema.colorScheme.secondary);
    final colorTexto = foregroundColor ?? Colors.white;
    
    final contenido = Row(
      mainAxisSize: expandido ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icono != null) ...[
          Icon(icono!, size: esGrande ? 24 : 20),
          SizedBox(width: 8),
        ],
        Text(
          texto,
          style: TextStyle(
            fontSize: esGrande ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final boton = ElevatedButton(
      onPressed: onPressed != null ? () {
        HapticFeedback.lightImpact();
        onPressed!();
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        foregroundColor: colorTexto,
        padding: EdgeInsets.symmetric(
          horizontal: esGrande ? 24 : 16,
          vertical: esGrande ? 16 : 12,
        ),
        minimumSize: Size(
          esGrande ? 120 : 88,
          esGrande ? 56 : 44,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: contenido,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: texto,
      child: expandido ? SizedBox(width: double.infinity, child: boton) : boton,
    );
  }
}

/// Chip de estado con colores semánticos
class ChipEstado extends StatelessWidget {
  final String texto;
  final EstadoChip estado;
  final bool esGrande;

  const ChipEstado({
    Key? key,
    required this.texto,
    required this.estado,
    this.esGrande = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _obtenerConfiguracionEstado(estado);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: esGrande ? 16 : 12,
        vertical: esGrande ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icono,
            color: config.color,
            size: esGrande ? 18 : 14,
          ),
          SizedBox(width: 6),
          Text(
            texto.toUpperCase(),
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.bold,
              fontSize: esGrande ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  _ConfiguracionEstado _obtenerConfiguracionEstado(EstadoChip estado) {
    switch (estado) {
      case EstadoChip.seguro:
        return _ConfiguracionEstado(
          color: ColoresAccesibles.seguro,
          icono: Icons.check_circle,
        );
      case EstadoChip.precaucion:
        return _ConfiguracionEstado(
          color: ColoresAccesibles.precaucion,
          icono: Icons.warning,
        );
      case EstadoChip.peligroso:
        return _ConfiguracionEstado(
          color: ColoresAccesibles.peligroso,
          icono: Icons.error,
        );
      case EstadoChip.info:
        return _ConfiguracionEstado(
          color: ColoresAccesibles.info,
          icono: Icons.info,
        );
      case EstadoChip.neutral:
        return _ConfiguracionEstado(
          color: ColoresAccesibles.neutral,
          icono: Icons.circle,
        );
    }
  }
}

enum EstadoChip { seguro, precaucion, peligroso, info, neutral }

class _ConfiguracionEstado {
  final Color color;
  final IconData icono;

  _ConfiguracionEstado({required this.color, required this.icono});
}

/// Header de sección con línea divisoria
class HeaderSeccion extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final Widget? accion;

  const HeaderSeccion({
    Key? key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.accion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icono != null) ...[
                Icon(
                  icono!,
                  color: ColoresAccesibles.seguro,
                  size: 24,
                ),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  titulo,
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColoresAccesibles.textoPrimario,
                  ),
                ),
              ),
              if (accion != null) accion!,
            ],
          ),
          if (subtitulo != null) ...[
            SizedBox(height: 4),
            Text(
              subtitulo!,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: ColoresAccesibles.textoSecundario,
              ),
            ),
          ],
          SizedBox(height: 12),
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              color: ColoresAccesibles.seguro,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de carga accesible
class IndicadorCarga extends StatelessWidget {
  final String? mensaje;
  final bool esGrande;

  const IndicadorCarga({
    Key? key,
    this.mensaje,
    this.esGrande = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: esGrande ? 48 : 32,
            height: esGrande ? 48 : 32,
            child: CircularProgressIndicator(
              strokeWidth: esGrande ? 4 : 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                ColoresAccesibles.seguro,
              ),
            ),
          ),
          if (mensaje != null) ...[
            SizedBox(height: 16),
            Text(
              mensaje!,
              style: TextStyle(
                fontSize: esGrande ? 16 : 14,
                color: ColoresAccesibles.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Container con información y estilo consistente
class ContenedorInfo extends StatelessWidget {
  final String titulo;
  final String contenido;
  final IconData icono;
  final Color? colorFondo;
  final Color? colorBorde;

  const ContenedorInfo({
    Key? key,
    required this.titulo,
    required this.contenido,
    required this.icono,
    this.colorFondo,
    this.colorBorde,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorBase = colorFondo ?? ColoresAccesibles.info;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorBase.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorBorde ?? colorBase.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorBase,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorBase,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  contenido,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColoresAccesibles.textoSecundario,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Espaciado consistente
class EspaciadoVertical extends StatelessWidget {
  final double alto;

  const EspaciadoVertical.pequeno({Key? key}) : alto = 8, super(key: key);
  const EspaciadoVertical.medio({Key? key}) : alto = 16, super(key: key);
  const EspaciadoVertical.grande({Key? key}) : alto = 24, super(key: key);
  const EspaciadoVertical.extraGrande({Key? key}) : alto = 32, super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: alto);
  }
}